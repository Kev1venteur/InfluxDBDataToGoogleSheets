import pandas as pd
import sys

def main():
    read_file = pd.read_excel (sys.argv[1], sheet_name=sys.argv[2], usecols=[1,2])
    read_file.to_csv (r'csv/conve!rted/{}.csv'.format(sys.argv[2]), index = None, header=True)

if __name__ == '__main__':
    main()
