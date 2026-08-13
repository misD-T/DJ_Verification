import csv
import os


def save_results_csv(
    filename,
    results,
    output_dir="results"
):
    """
    Save experiment results to a CSV file.

    Parameters
    ----------
    filename:
        Name of the CSV file.

    results:
        List of dictionaries containing experiment results.

    output_dir:
        Directory in which the CSV should be written.
    """

    if not results:
        return


    os.makedirs(
        output_dir,
        exist_ok=True
    )


    filepath = os.path.join(
        output_dir,
        filename
    )


    keys = results[0].keys()


    with open(
        filepath,
        "w",
        newline=""
    ) as f:

        writer = csv.DictWriter(
            f,
            fieldnames=keys
        )

        writer.writeheader()

        writer.writerows(
            results
        )


    print(
        f"\nSaved results to {filepath}"
    )


