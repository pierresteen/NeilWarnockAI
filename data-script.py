import pandas as pd
import os
import pathlib
import click

"""
Necessary commands:

    prep_csv:

        PARAMS:
        year -> str
        buffer -> int

"""

FILE_PATH = pathlib.Path(__file__).parent.absolute()


@click.command()
@click.option('--year', default='2018-19', help='PL Season year.')
@click.option('--buffer', default=5, help='Number of previous GWs to consider.')
def main(year, buffer):
    """
    Steps:
        - Goto folder specified by year
        - Create pandas DF 
    """
    while True:
        try:
            gw = int(input("Enter current GW: "))
        except:
            print('Enter an int')
            continue
        if gw - buffer < 1 or gw > 38:
            print('Enter a valid GW')
            continue
        break

    year_folder = pathlib.Path('./data/'+str(year)+'/gws/')
    if not year_folder.exists():
        print('Year folder does not exist')
        exit()

    csv_files = []
    for i in reversed(range(1, buffer+1)):
        csv_files.append(pd.read_csv(
            year_folder.joinpath('gw'+str(gw-i)+'.csv')))

    all_files = pd.concat(csv_files)
    result = all_files.groupby(all_files.index).mean()

    print(result.head())


if __name__ == "__main__":
    main()
