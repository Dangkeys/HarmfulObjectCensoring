#!/bin/bash

# Script to merge taj and eyey folders into a single combined folder
# This script merges both images and labels from taj and eyey into a new 'merged' folder

# Base dataset directory
BASE_DIR="$(dirname "$0")/dataset"

# Source directories
TAJ_IMAGES_DIR="$BASE_DIR/images/taj"
TAJ_LABELS_DIR="$BASE_DIR/labels/taj"
EYEY_IMAGES_DIR="$BASE_DIR/images/eyey"
EYEY_LABELS_DIR="$BASE_DIR/labels/eyey"

# Destination directories
MERGED_IMAGES_DIR="$BASE_DIR/images/merged"
MERGED_LABELS_DIR="$BASE_DIR/labels/merged"

echo "🔄 Starting folder merge process..."
echo "📂 Base directory: $BASE_DIR"
echo ""

# Create destination directories
echo "📁 Creating merged directories..."
mkdir -p "$MERGED_IMAGES_DIR" "$MERGED_LABELS_DIR"

# Function to copy files and show progress
copy_files() {
    local source_dir="$1"
    local dest_dir="$2"
    local file_type="$3"
    local folder_name="$4"
    
    if [[ ! -d "$source_dir" ]]; then
        echo "⚠️  Warning: $source_dir doesn't exist, skipping..."
        return
    fi
    
    local file_count=$(find "$source_dir" -type f | wc -l)
    echo "📦 Copying $file_count $file_type files from $folder_name..."
    
    if [[ $file_count -gt 0 ]]; then
        cp "$source_dir"/* "$dest_dir/" 2>/dev/null
        echo "✅ Successfully copied $file_count $file_type files from $folder_name"
    else
        echo "📭 No files found in $folder_name $file_type directory"
    fi
}

# Copy images from both folders
echo "🖼️  Merging images..."
copy_files "$TAJ_IMAGES_DIR" "$MERGED_IMAGES_DIR" "image" "taj"
copy_files "$EYEY_IMAGES_DIR" "$MERGED_IMAGES_DIR" "image" "eyey"

echo ""

# Copy labels from both folders
echo "🏷️  Merging labels..."
copy_files "$TAJ_LABELS_DIR" "$MERGED_LABELS_DIR" "label" "taj"
copy_files "$EYEY_LABELS_DIR" "$MERGED_LABELS_DIR" "label" "eyey"

echo ""

# Show final statistics
echo "📊 Merge Statistics:"
merged_images=$(find "$MERGED_IMAGES_DIR" -type f | wc -l)
merged_labels=$(find "$MERGED_LABELS_DIR" -type f | wc -l)

echo "   🖼️  Total merged images: $merged_images"
echo "   🏷️  Total merged labels: $merged_labels"

# Check if counts match
if [[ $merged_images -eq $merged_labels ]]; then
    echo "✅ Perfect! Image and label counts match"
else
    echo "⚠️  Warning: Image count ($merged_images) and label count ($merged_labels) don't match"
fi

echo ""
echo "📁 Merged folders created:"
echo "   🖼️  Images: $MERGED_IMAGES_DIR"
echo "   🏷️  Labels: $MERGED_LABELS_DIR"

echo ""
read -p "🗑️  Do you want to delete the original taj and eyey folders? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting original folders..."
    
    # Remove taj folders
    if [[ -d "$TAJ_IMAGES_DIR" ]]; then
        rm -rf "$TAJ_IMAGES_DIR"
        echo "✅ Deleted: $TAJ_IMAGES_DIR"
    fi
    if [[ -d "$TAJ_LABELS_DIR" ]]; then
        rm -rf "$TAJ_LABELS_DIR"
        echo "✅ Deleted: $TAJ_LABELS_DIR"
    fi
    
    # Remove eyey folders
    if [[ -d "$EYEY_IMAGES_DIR" ]]; then
        rm -rf "$EYEY_IMAGES_DIR"
        echo "✅ Deleted: $EYEY_IMAGES_DIR"
    fi
    if [[ -d "$EYEY_LABELS_DIR" ]]; then
        rm -rf "$EYEY_LABELS_DIR"
        echo "✅ Deleted: $EYEY_LABELS_DIR"
    fi
    
    echo "🎉 Original folders deleted successfully!"
else
    echo "📂 Original folders kept intact"
fi

echo ""
echo "🎉 Merge process completed!"