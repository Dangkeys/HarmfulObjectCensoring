#!/bin/bash

# Base dataset directory
BASE_DIR="$(dirname "$0")/dataset"
IMAGES_TEST_DIR="$BASE_DIR/images/test"
LABELS_TEST_DIR="$BASE_DIR/labels/test"

# Output directories for train/val split
TRAIN_IMAGES_DIR="$BASE_DIR/images/taj"
TRAIN_LABELS_DIR="$BASE_DIR/labels/taj"
VAL_IMAGES_DIR="$BASE_DIR/images/eyey"
VAL_LABELS_DIR="$BASE_DIR/labels/eyey"

# Number of total images to sample
TOTAL=25000
# Number of images per folder (train: 12,500, val: 12,500)
HALF=$((TOTAL / 2))

# Create output directories
mkdir -p "$TRAIN_IMAGES_DIR" "$TRAIN_LABELS_DIR" "$VAL_IMAGES_DIR" "$VAL_LABELS_DIR"

echo "📂 Scanning for images with corresponding labels..."

# Find all image files in test directory and check if they have corresponding labels
TEMP_DIR=$(mktemp -d)
PAIRED_FILES="$TEMP_DIR/paired_files.txt"

# Find all .jpg files in test images directory
find "$IMAGES_TEST_DIR" -name "*.jpg" -type f | while read image_file; do
    # Get the base name without extension
    base_name=$(basename "$image_file" .jpg)
    # Check if corresponding label file exists
    label_file="$LABELS_TEST_DIR/$base_name.txt"
    
    if [[ -f "$label_file" ]]; then
        echo "$image_file" >> "$PAIRED_FILES"
    fi
done

# Count total paired files found
TOTAL_PAIRED=$(wc -l < "$PAIRED_FILES")
echo "📊 Found $TOTAL_PAIRED images with corresponding labels"

if [[ $TOTAL_PAIRED -lt $TOTAL ]]; then
    echo "⚠️  Warning: Only $TOTAL_PAIRED paired files found, but $TOTAL requested"
    echo "📉 Will sample all available paired files"
    ACTUAL_TOTAL=$TOTAL_PAIRED
    ACTUAL_HALF=$((ACTUAL_TOTAL / 2))
else
    ACTUAL_TOTAL=$TOTAL
    ACTUAL_HALF=$HALF
    echo "✅ Sufficient paired files found for sampling"
fi

# Randomly shuffle and select the required number of paired files
echo "🔀 Shuffling and selecting $ACTUAL_TOTAL paired files..."
shuf "$PAIRED_FILES" | head -n "$ACTUAL_TOTAL" > "$TEMP_DIR/selected_files.txt"

# Split into train and val sets
echo "📚 Creating train set ($ACTUAL_HALF files)..."
head -n "$ACTUAL_HALF" "$TEMP_DIR/selected_files.txt" | while read image_file; do
    # Copy image
    cp "$image_file" "$TRAIN_IMAGES_DIR/"
    
    # Copy corresponding label
    base_name=$(basename "$image_file" .jpg)
    label_file="$LABELS_TEST_DIR/$base_name.txt"
    cp "$label_file" "$TRAIN_LABELS_DIR/"
done

echo "🔬 Creating validation set ($ACTUAL_HALF files)..."
tail -n "$ACTUAL_HALF" "$TEMP_DIR/selected_files.txt" | while read image_file; do
    # Copy image
    cp "$image_file" "$VAL_IMAGES_DIR/"
    
    # Copy corresponding label
    base_name=$(basename "$image_file" .jpg)
    label_file="$LABELS_TEST_DIR/$base_name.txt"
    cp "$label_file" "$VAL_LABELS_DIR/"
done

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Done! Dataset split completed."
echo "📈 Train set: $ACTUAL_HALF paired files"
echo "   📂 Images: $TRAIN_IMAGES_DIR"
echo "   🏷️  Labels: $TRAIN_LABELS_DIR"
echo "📊 Validation set: $ACTUAL_HALF paired files"
echo "   📂 Images: $VAL_IMAGES_DIR"
echo "   🏷️  Labels: $VAL_LABELS_DIR"
