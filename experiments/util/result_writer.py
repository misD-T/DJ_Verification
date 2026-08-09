import csv
import os


def save_results_csv(
        filename,
        results
):

    if not results:
        return


    os.makedirs(
        "results",
        exist_ok=True
    )


    filepath = os.path.join(
        "results",
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