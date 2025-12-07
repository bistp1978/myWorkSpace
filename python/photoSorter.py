import os
import shutil
from datetime import datetime
from PIL import Image
from PIL.ExifTags import TAGS

# -----------------------------
# CONFIGURE THIS PATH
# -----------------------------
SOURCE_FOLDER = r"D:\MeenuMobile\Camera"
# -----------------------------


def get_exif_date(file_path):
    """Extract date from EXIF metadata if available"""
    try:
        img = Image.open(file_path)
        exif = img._getexif()
        if exif is not None:
            for tag_id, value in exif.items():
                tag = TAGS.get(tag_id, tag_id)
                if tag == "DateTimeOriginal":
                    return datetime.strptime(value, "%Y:%m:%d %H:%M:%S")
    except Exception:
        pass
    return None


def get_file_date(file_path):
    """Fallback: use filesystem creation time"""
    timestamp = os.path.getctime(file_path)
    return datetime.fromtimestamp(timestamp)


def sort_images_by_date(source_folder):
    for filename in os.listdir(source_folder):
        file_path = os.path.join(source_folder, filename)

        if not os.path.isfile(file_path):
            continue

        # Only process common media formats
        if not filename.lower().endswith((
            ".jpg", ".jpeg", ".png", ".heic", ".mp4", ".mov"
        )):
            continue

        # Try EXIF date first
        file_date = get_exif_date(file_path)

        # Fallback to file creation date
        if file_date is None:
            file_date = get_file_date(file_path)

        year = str(file_date.year)
        month = file_date.strftime("%B")  # e.g. "January", "February"

        # Create target folder path
        target_folder = os.path.join(source_folder, year, month)
        os.makedirs(target_folder, exist_ok=True)

        # Move file
        target_path = os.path.join(target_folder, filename)
        print(f"Moving: {filename} → {year}/{month}")

        shutil.move(file_path, target_path)

    print("\nSorting completed!")


if __name__ == "__main__":
    sort_images_by_date(SOURCE_FOLDER)
