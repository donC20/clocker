from PIL import Image
import os

src = r"C:\Users\donbe\.gemini\antigravity\brain\981a6206-7d69-499b-9cd0-3417c643e648\clocker_app_icon_1774106773745.png"
base_dir = r"e:\OBN\clocker"

def save_icon(img, path, size):
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(path, "PNG")
    print(f"Saved {size}x{size} to {path}")

img = Image.open(src)

# Assets
save_icon(img, os.path.join(base_dir, "assets", "images", "app_icon.png"), 1024)

# Android Mipmaps
mipmap_configs = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192
}

for res, size in mipmap_configs.items():
    path = os.path.join(base_dir, "android", "app", "src", "main", "res", f"mipmap-{res}", "ic_launcher.png")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    save_icon(img, path, size)

# Web Icons
web_dir = os.path.join(base_dir, "web", "icons")
os.makedirs(web_dir, exist_ok=True)
save_icon(img, os.path.join(web_dir, "Icon-192.png"), 192)
save_icon(img, os.path.join(web_dir, "Icon-512.png"), 512)
save_icon(img, os.path.join(web_dir, "Icon-maskable-192.png"), 192)
save_icon(img, os.path.join(web_dir, "Icon-maskable-512.png"), 512)
save_icon(img, os.path.join(base_dir, "web", "favicon.png"), 64)

print("Icons successfully updated and converted to PNG.")
