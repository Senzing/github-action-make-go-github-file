# github-action-make-go-github-file

## Synopsis

Make a github.go file.

## Overview

The github action creates a pull request with updated values in `github.go`.

## Usage

1. A `.github/workflows/make-go-github-file.yaml` file
   that creates a `cmd/github.go` file for "package cmd".
   Example:

    ```yaml
    name: make-go-github-file.yaml

    on:
      push:
        tags:
          - "[0-9]+.[0-9]+.[0-9]+"

    jobs:
      build:
        name: Update cmd/github.go
        runs-on: ubuntu-latest
        steps:
          - name: Checkout repository
            uses: actions/checkout@v3
            with:
              fetch-depth: '0'
          - name: Make github.go file
            uses: Senzing/github-action-make-go-github-file@main
    ```

1. A `.github/workflows/make-go-github-file.yaml` file
   that creates a `example/example.go` file for "package myexample".
   Example:

    ```yaml
    name: make-go-github-file.yaml

    on:
      push:
        tags:
          - "[0-9]+.[0-9]+.[0-9]+"

    jobs:
      build:
        name: Update cmd/github.go
        runs-on: ubuntu-latest
        steps:
          - name: Checkout repository
            uses: actions/checkout@v3
            with:
              fetch-depth: '0'
          - name: Make github.go file
            uses: Senzing/github-action-make-go-github-file@main
            with:
              file: example/example.go
              package: myexample
    ```
