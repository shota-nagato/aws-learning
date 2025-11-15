from datetime import datetime, timezone

def handler(event, context):
    # Parse query parameters
    query_params = event.get('queryStringParameters', {}) or {}
    
    try:

        # We only accept integers
        num1 = int(query_params.get('num1', '0'))
        num2 = int(query_params.get('num2', '0'))
        sum_result = num1 + num2
        
            
        # Get CloudFront headers
        headers = event.get('headers', {})
        headers["x-amz-security-token"] = "{hidden}"
        headers_html = ''.join([
            f'<tr><td>{k}</td><td>{v}</td></tr>' 
            for k, v in sorted(headers.items())
        ])
        
        # Generate HTML response
        html = f'''<!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Addition Result</title>
            <link rel="stylesheet" href="/static/css/result.css">
        </head>
        <body>
            <div class="result-container">
                <h1>Addition Result</h1>
                <div class="result">
                    {num1} + {num2} = {sum_result}
                </div>
                <h1>Computed at</h1>
                <div class="result">
                    {datetime.now(timezone.utc).isoformat(timespec="seconds")}
                </div>
                <h2>CloudFront Headers</h2>
                <table class="headers-table">
                    <thead>
                        <tr>
                            <th>Header Name</th>
                            <th>Value</th>
                        </tr>
                    </thead>
                    <tbody>
                        {headers_html}
                    </tbody>
                </table>
                <a href="/" class="back-link">Calculate Another Sum</a>
            </div>
        </body>
        </html>
        '''
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/html',
            },
            'body': html
        }
        
    except Exception as e:
        return {
            'statusCode': 400,
            'body': f'Error calculating sum: {str(e)}'
        }
