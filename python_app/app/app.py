import random, boto3
from flask import Flask, render_template
from jsonpath_ng import parse

bucket_name = 'decathlon-site-data'


def get_random_image_from_s3bucket():
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(
        Bucket=bucket_name,
        Prefix='image',
        MaxKeys=100)
    jsonpath_expression = parse('Contents[*].Key')
    objects = list()
    for match in jsonpath_expression.find(response):
        objects.append(match.value)
    return random.choice(objects)


app = Flask(__name__)


@app.route('/')
def home():
    return render_template("index.html", bucket_name=bucket_name, object_key=get_random_image_from_s3bucket())
    # return render_template("index.html")

if __name__ == '__main__':
    # app.run(port=8080)
    app.run(host='0.0.0.0', port=8080)
