#!/bin/bash

# Script to clean up orphaned label files
# This script deletes label files that don't have corresponding image files

# Base dataset directory
BASE_DIR="$(dirname "$0")/dataset"

# Function to clean up labels in a specific directory
cleanup_labels() {
    local images_dir="$1"
    local labels_dir="$2"
    local folder_name="$3"
    
    if [[ ! -d "$images_dir" ]] || [[ ! -d "$labels_dir" ]]; then
        echo "⚠️  Skipping $folder_name: Directory doesn't exist"
        return
    fi
    
    echo "🧹 Cleaning up labels in $folder_name..."
    
    local deleted_count=0
    local total_labels=0
    
    # Count total label files
    total_labels=$(find "$labels_dir" -name "*.txt" -type f | wc -l)
    echo "📊 Found $total_labels label files in $labels_dir"
    
    # Check each label file
    find "$labels_dir" -name "*.txt" -type f | while read label_file; do
        # Get the base name without extension
        base_name=$(basename "$label_file" .txt)
        # Check if corresponding image file exists
        image_file="$images_dir/$base_name.jpg"
        
        if [[ ! -f "$image_file" ]]; then
            echo "🗑️  Deleting orphaned label: $(basename "$label_file")"
            rm "$label_file"
            ((deleted_count++))
        fi
    done
    
    # Recount after deletion
    local remaining_labels=$(find "$labels_dir" -name "*.txt" -type f | wc -l)
    local actually_deleted=$((total_labels - remaining_labels))
    
    echo "✅ Cleanup complete for $folder_name:"
    echo "   📉 Deleted: $actually_deleted orphaned label files"
    echo "   📈 Remaining: $remaining_labels label files"
    echo ""
}

echo "🧹 Starting label cleanup process..."
echo "📂 Base directory: $BASE_DIR"
echo ""

# Clean up labels in test directory
cleanup_labels "$BASE_DIR/images/test" "$BASE_DIR/labels/test" "test"

# Clean up labels in taj directory  
cleanup_labels "$BASE_DIR/images/taj" "$BASE_DIR/labels/taj" "taj"

# Clean up labels in eyey directory
cleanup_labels "$BASE_DIR/images/eyey" "$BASE_DIR/labels/eyey" "eyey"

echo "🎉 All label cleanup completed!"