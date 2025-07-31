import boto3
import os
import subprocess

s3 = boto3.client('s3')

def download_file(bucket, key, dest):
    try:
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        s3.download_file(bucket, key, dest)
    except Exception as e:
        print(f"Error downloading file: {e}")
        return False
    return True

def scan_file(file_path):
    result = subprocess.run(['clamscan', file_path], capture_output=True, text=True)
    print(result.stdout)
    return result.returncode == 1

def handle_file(bucket, key):
    local_file = f"/tmp/{key}"

    if not download_file(bucket, key, local_file):
        return

    if scan_file(local_file):
        print("File is infected!")
        s3.copy_object(
            Bucket='quarantine-bucket-file',
            CopySource=f"{bucket}/{key}",
            Key=key
        )
    else:
        print("File is clean.")
        s3.copy_object(
            Bucket=bucket,
            CopySource=f"{bucket}/{key}",
            Key=f"clean/{key}"
        )
    
    os.remove(local_file)

if __name__ == "__main__":
    handle_file('secure-upload-bucket-re', 'incoming/Cloud_engineer.pdf')
