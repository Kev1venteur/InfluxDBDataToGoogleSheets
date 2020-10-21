from __future__ import print_function
import pickle
import gspread
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# Delete tocken.pickles file every time you change the scopes
SCOPES = ['https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive']

# The ID and range of a sample spreadsheet.
SPREADSHEET_ID = '1MlvFP0t9QS_5DHF1xBhXcldJby3DAvUHZQH-EC1GRYU'
worksheet_name = 'test'
csv_path = 'raw-csv-data.csv'
creds_path = 'token.pickle'

def main():
    """Shows basic usage of the Sheets API.
    Prints values from a sample spreadsheet.
    """
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
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    service = build('sheets', 'v4', credentials=creds)

    # convenience routines
    def find_sheet_id_by_name(sheet_name):
        # ugly, but works
        sheets_with_properties = API \
            .spreadsheets() \
            .get(spreadsheetId=SPREADSHEET_ID, fields='sheets.properties') \
            .execute() \
            .get('sheets')

        for sheet in sheets_with_properties:
            if 'title' in sheet['properties'].keys():
                if sheet['properties']['title'] == sheet_name:
                    return sheet['properties']['sheetId']


    def push_csv_to_gsheet(csv_path, sheet_id):
        with open(csv_path, 'r') as csv_file:
            csvContents = csv_file.read()
        body = {
            'requests': [{
                'pasteData': {
                    "coordinate": {
                        "sheetId": sheet_id,
                        "rowIndex": "0",  # adapt this if you need different positioning
                        "columnIndex": "0", # adapt this if you need different positioning
                    },
                    "data": csvContents,
                    "type": 'PASTE_NORMAL',
                    "delimiter": ',',
                }
            }]
        }
        request = API.spreadsheets().batchUpdate(spreadsheetId=SPREADSHEET_ID, body=body)
        response = request.execute()
        return response


    # upload
    with open(creds_path, 'rb') as token:
        credentials = pickle.load(token)

    API = build('sheets', 'v4', credentials=credentials)

    push_csv_to_gsheet(
        csv_path=csv_path,
        sheet_id=find_sheet_id_by_name(worksheet_name)
    )

if __name__ == '__main__':
    main()
