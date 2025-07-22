#    Copyright 2025 Genesis Corporation.
#
#    All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import os
import json
import argparse


def main(env_prefix, output_path):
    # Filter environment variables by prefix
    env_vars = {
        k[len(env_prefix) :]: v
        for k, v in os.environ.items()
        if k.startswith(env_prefix)
    }

    # Write to json file
    try:
        with open(output_path, "w") as json_file:
            json.dump(env_vars, json_file, indent=4)
        print(f"JSON file was created successfully at {output_path}")
    except IOError as e:
        print(f"An error occurred while writing the JSON file: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Create a JSON file from environment variables "
            "with a specific prefix."
        )
    )
    parser.add_argument(
        "--prefix",
        type=str,
        default="UI_BUILD_ENV_",
        help="The environment variable prefix to filter for.",
    )
    parser.add_argument(
        "--path",
        type=str,
        default="env.json",
        help="The path to output the JSON file.",
    )

    args = parser.parse_args()

    main(args.prefix, args.path)
