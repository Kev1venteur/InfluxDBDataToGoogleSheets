from __future__ import print_function
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from google.oauth2 import service_account
import pickle
import gspread
import os

#----------The infos of a spreadsheet you have to modify----------------#
#Get the spreadsheet id in the url from your browser
SPREADSHEET_ID = '1MlvFP0t9QS_5DHF1xBhXcldJby3DAvUHZQH-EC1GRYU'
#-----------------------------------------------------------------------#

# Delete tocken.pickles file every time you change the scopes
SCOPES = ['https://www.googleapis.com/auth/spreadsheets',
          'https://www.googleapis.com/auth/drive']

csv_base_path = 'csv/formatted/'
token_path = 'credentials/token.pickle'
creds_file_path = 'credentials/credentials.json'

def main():
    #Creating creds with service account, the service.json key and the affected scopes
    creds = service_account.Credentials.from_service_account_file('credentials/service.json', scopes=SCOPES)

    #Building service with API type, version, and creds
    service = build('sheets', 'v4', credentials=creds)

    #Push your CSV to sheet identified by it's ID, in a defined range 
    def push_csv_to_gsheet(csv_path, sheet_id, range):
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
                        "rowIndex": last_row_id,
                        "columnIndex": "0",
                    },
                    "data": csvContents,
                    "type": 'PASTE_NORMAL',
                    "delimiter": ',',
                }
            }]
        }
        request = service \
            .spreadsheets() \
            .batchUpdate(spreadsheetId=SPREADSHEET_ID, body=body)

        request.InsertDataOption = "INSERT_ROWS"
        response = request.execute()
        return response

    def find_sheet_id_by_name(sheet_name):
        #ugly, but works
        sheets_with_properties = service \
            .spreadsheets() \
            .get(spreadsheetId=SPREADSHEET_ID, fields='sheets.properties') \
            .execute() \
            .get('sheets')

        for sheet in sheets_with_properties:
            if 'title' in sheet['properties'].keys():
                if sheet['properties']['title'] == sheet_name:
                    return sheet['properties']['sheetId']

    #For each files in csv/formatted push into sheet with same name (bug if sheet name does not exist)
    for filename in os.listdir(csv_base_path):
        #Setting range of box to consider in sheet
        range = filename + "!A2:D"
        #Setting CSV path with base path + hostname
        csv_path = csv_base_path + filename
        #Pushing data to sheet
        push_csv_to_gsheet(
            csv_path=csv_path,
            sheet_id=find_sheet_id_by_name(filename),
            range=range
        )
        continue

    print("Done.")

if __name__ == '__main__':
    main()
