# Pipeline Backend

The backend code for Project Pipeline

## Notes
* for JWT to work, you need to manually add a jwt token `jwtKey.key` (ignored by git) to the project's directory.
* add a `config.json` containing the following:
```json
    {
        "googleClientID": "your client id",
        "googleClientSecret": "your client secret",
        "googleCallbackURL": "your callback url",
        "mongoURL": "your mongo url in base64 encoded form",
        "unrestrictedCORS": "true/false"
    }
```
* Run `source setup.sh` to setup the essential environmental variables for this project.
    

