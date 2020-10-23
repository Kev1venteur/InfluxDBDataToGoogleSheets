#I used Python 3.8 from MS store

from __future__ import print_function
import pickle
import gspread
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import os

#Use this only if you have a proxy
os.environ['REQUESTS_CA_BUNDLE'] = 'cacert.pem'
#put a copy of your certificate in the current script folder and
#then duplicate your it to :
#C:\Users\kgillet\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.9_qbz5n2kfra8p0\LocalCache\local-packages\Python39\site-packages\certifi
#and replace cacert.pem with your cert

# Delete tocken.pickles file every time you change the scopes
SCOPES = ['https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive']

# The infos of a spreadsheet.
SPREADSHEET_ID = '1MlvFP0t9QS_5DHF1xBhXcldJby3DAvUHZQH-EC1GRYU'
worksheet_name = 'test'
csv_path = 'formatted-csv-data.csv'
token_path = 'token.pickle'
creds_file_path = 'credentials.json'
range = "test!A2:D"
#Here specify the sheet id you want to write on (gid number in URL)
sheet_id_from_URL = "111999247"

def main():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                creds_file_path, SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    service = build('sheets', 'v4', credentials=creds)

    def push_csv_to_gsheet(csv_path, sheet_id):
        #Get last filled row to insert after it
        rows = service \
            .spreadsheets() \
            .values() \
            .get(spreadsheetId=SPREADSHEET_ID, range=range) \
            .execute() \
            .get('values', [])

        last_row = rows[-1] if rows else None
        last_row_id = len(rows) + 1

        with open(csv_path, 'r') as csv_file:
            csvContents = csv_file.read()

        body = {
            'requests': [{
                'pasteData': {
                    "coordinate": {
                        "sheetId": sheet_id,
                        "rowIndex": last_row_id,  # adapt this if you need different positioning
                        "columnIndex": "0", # adapt this if you need different positioning
                    },
                    "data": csvContents,
                    "type": 'PASTE_NORMAL',
                    "delimiter": ',',
                }
            }]
        }
        request = API \
            .spreadsheets() \
            .batchUpdate(spreadsheetId=SPREADSHEET_ID, body=body)

        request.InsertDataOption = "INSERT_ROWS"
        response = request.execute()
        return response

    # upload
    with open(token_path, 'rb') as token:
        credentials = pickle.load(token)

    API = build('sheets', 'v4', credentials=credentials)

    push_csv_to_gsheet(
        csv_path=csv_path,
        sheet_id=sheet_id_from_URL
    )

if __name__ == '__main__':
    main()
