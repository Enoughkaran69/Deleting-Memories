from deepface import DeepFace
from flask import Flask, request, jsonify, send_from_directory
import os

app = Flask(__name__)

# Folder to store uploaded files
UPLOAD_FOLDER = './uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/upload_and_analyze', methods=['POST'])
def upload_and_analyze():
    try:
        # Save the target image
        target_image = request.files['target_image']
        target_path = os.path.join(UPLOAD_FOLDER, 'target.jpg')
        target_image.save(target_path)

        # Save gallery images
        uploaded_files = request.files.getlist('gallery_images')
        matched_results = []

        for file in uploaded_files:
            file_path = os.path.join(UPLOAD_FOLDER, file.filename)
            file.save(file_path)

            # Perform face verification
            try:
                result = DeepFace.verify(target_path, file_path, model_name='Facenet')
                if result['verified']:
                    # Return the public URL of the matched file
                    matched_results.append(f"http://{request.host}/uploads/{file.filename}")
            except Exception as e:
                print(f"Error comparing {file.filename}: {e}")

        # Return the matched images as URLs
        return jsonify({"matched_images": matched_results})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/uploads/<filename>', methods=['GET'])
def get_uploaded_file(filename):
    """Serve uploaded files."""
    return send_from_directory(UPLOAD_FOLDER, filename)


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
