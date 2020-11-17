from __future__ import print_function
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import pickle
import gspread
import os

#----------The infos of a spreadsheet you have to modify----------------#
#Get the spreadsheet id in the url from your browser
SPREADSHEET_ID = '1MlvFP0t9QS_5DHF1xBhXcldJby3DAvUHZQH-EC1GRYU'
#Here specify the sheet name you want to write on
sheet_name = 'Feuille 2'
#Here specify the sheet id you want to write on (gid number in URL)
sheet_id_from_URL = "547949283"
#-----------------------------------------------------------------------#

# Delete tocken.pickles file every time you change the scopes
SCOPES = ['https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive']

csv_path = 'csv/formatted/formatted-influx-data.csv'
token_path = 'credentials/token.pickle'
creds_file_path = 'credentials/credentials.json'
range = sheet_name + "!A2:D"

def main():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists(token_path):
        with open(token_path, 'rb') as token:
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
        with open(token_path, 'wb') as token:
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
        range_prefix = range
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

    print("Done.")

if __name__ == '__main__':
    main()
