package PostNewActivity

import (
	"context"
	"fmt"
	"log"
	"strings"
	"time"

)

type Post struct {
	Author struct {
		StringValue string `json:"stringValue"`
	} `json:"author"`
	Time struct {
		StringValue string `json:"stringValue"`
	} `json:"time"`
	Title struct {
		StringValue string `json:"stringValue"`
	} `json:"title"`
	Body struct {
		StringValue string `json:"stringValue"`
	} `json:"body"`
	Tags struct {
		ArrayValue struct {
			Values []struct {
				StringValue string `json:"stringValue"`
			} `json:"values"`
		} `json:"arrayValue"`
	} `json:"tags"`
}

type FirestoreEvent struct {
	OldValue   FirestoreValue `json:"oldValue"`
	Value      FirestoreValue `json:"value"`
	UpdateMask struct {
		FieldPaths []string `json:"fieldPaths"`
	} `json:"updateMask"`
}

type FirestoreValue struct {
	CreateTime time.Time `json:"createTime"`
	Fields     Post      `json:"fields"`
	Name       string    `json:"name"`
	UpdateTime time.Time `json:"updateTime"`
}

func PostNewActivity(ctx context.Context, e FirestoreEvent) error {
	projectID := "untitled-2832f"

	// load new post data into post
	post := e.Value.Fields

	// firestore client
	client, err := firestore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	// Get the author's document
	authorDoc, err := client.Collection("users").Doc(post.Author.StringValue).Get(ctx)
	if err != nil {
		log.Fatalf("Failed to get author document: %v", err)
	}

	// Get the author's username
	username, ok := authorDoc.Data()["username"].(string)
	if !ok {
		log.Fatalf("Failed to convert username to string")
	}

	// Get the author's uid
	uid, ok := authorDoc.Data()["uid"].(string)
	if !ok {
		log.Fatalf("Failed to convert uid to string")
	}

	// split the path to just get the document id
	path := e.Value.Name
	splitPath := strings.Split(path, "/")
	lastPart := splitPath[len(splitPath)-1]

	// format content
	var content string
	if post.Title.StringValue != "" {
		content = post.Title.StringValue
	} else if post.Body.StringValue != "" {
		content = post.Body.StringValue
	} else {
		content = fmt.Sprintf("New post from %s", username)
	}

	// Check if the post is public
	isPublic := false
	for _, tag := range post.Tags.ArrayValue.Values {
		if tag.StringValue == "public" {
			isPublic = true
			break
		}
	}

	if isPublic { // if public send to each follower
		// Get the author's profileData
		profileData, ok := authorDoc.Data()["profileData"].(map[string]interface{})
		if !ok {
			log.Fatalf("Failed to convert profileData to map")
		}

		// Get the author's followers
		followers, ok := profileData["followers"].([]interface{})
		if !ok {
			log.Fatalf("Failed to convert followers to array")
		}
		// For each follower, add the new activity
		for _, follower := range followers {
			followerID, ok := follower.(string)
			if !ok {
				log.Printf("Failed to convert follower ID to string")
				continue
			}
			_, _, err = client.Collection("users").Doc(followerID).Collection("newActivity").Add(ctx, map[string]interface{}{
				"content":   content,
				"path":      lastPart,
				"sourceUid": uid,
				"time":      post.Time.StringValue,
				"type":      "post",
				"tags":      "public",
			})
			if err != nil {
				log.Fatalf("Failed to add activity: %v", err)
			}
		}
	} else {
		// Group-targeted fanout has been removed along with the groups feature.
		log.Printf("Skipping non-public post activity fanout for post %s", lastPart)
	}

	return nil
}

// gcloud functions deploy PostNewActivity --runtime go121 --trigger-event "providers/cloud.firestore/eventTypes/document.create" --trigger-resource "projects/untitled-2832f/databases/(default)/documents/posts/{docId}"
