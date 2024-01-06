# Molecule action

A GitHub action to test your [Ansible](https://www.ansible.com/) role using
[Molecule](https://ansible.readthedocs.io/projects/molecule/).

## Requirements

This action can work with Molecule scenarios that use the
[`docker`](https://ansible.readthedocs.io/projects/molecule/configuration/)
driver.

This action expects the following (default Ansible role) structure:

```text
.
├── defaults
│   └── main.yml
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── molecule
│   └── default
│       ├── molecule.yml
│       ├── playbook.yml
│       └── prepare.yml
├── requirements.yml
├── tasks
│   └── main.yml
├── tox.ini # OPTIONAL
└── vars
    └── main.yml
```

If you are missing the `molecule` directory, please have a look at this
[skeleton role](https://github.com/robertdebock/ansible-role-skeleton) or one of
the many examples listed on [Robert de Bock's site](https://robertdebock.nl/).

When `tox.ini` is found, [tox](https://tox.wiki/en/latest/) is used to test the
role. Tox will install all dependencies found in `tox.ini` itself, meaning
`tox.ini` determines the version of
[molecule](https://ansible.readthedocs.io/projects/molecule/) that is used.

## Inputs

### `namespace`

The Docker Hub namespace where the image is in. Default `"robertdebock"`.

### `image`

The image you want to run on. Default `"fedora"`.

### `tag`

The tag of the container image to use. Default `"latest"`.

### `options`

The [options to pass to `tox`](https://tox.wiki/en/latest/config.html#tox). For
example `parallel`. Default `""`. (empty)

### `command`

The molecule command to use. For example `create`. Default `"test"`.

### `scenario`

The molecule scenario to run. Default `"default"`

## Example usage

Here is a default configuration that tests your role on `namespace:
robertdebock`, `image: fedora`, `tag: latest`.

```yaml
---
on:
  - push

jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - name: checkout
        uses: actions/checkout@v4.1.1
        with:
          path: "${{ github.repository }}"
      - name: molecule
        uses: balling-dev/molecule-action@1.0.0
```

> NOTE: the `checkout` action needs to place the file in
> `${{ github.repository }}` in order for Molecule to find your role.

If you want to test your role against multiple distributions, you can use this
pattern:

```yaml
---
name: CI

on:
  - push

jobs:
  lint:
    runs-on: ubuntu-22.04
    steps:
      - name: checkout
        uses: actions/checkout@v4.1.1
        with:
          path: "${{ github.repository }}"
      - name: molecule
        uses: balling-dev/molecule-action@1.0.0
        with:
          command: lint
  test:
    needs:
      - lint
    runs-on: ubuntu-22.04
    strategy:
      matrix:
        image:
          - alpine
          - amazonlinux
          - debian
          - centos
          - fedora
          - opensuse
          - ubuntu
    steps:
      - name: checkout
        uses: actions/checkout@v4.1.1
        with:
          path: "${{ github.repository }}"
      - name: molecule
        uses: balling-dev/molecule-action@1.0.0
        with:
          image: "${{ matrix.image }}"
          options: parallel
          scenario: my_specific_scenario
```

## Debugging

You can enable Molecule debugging by using this pattern:

```yaml
# Stuff omitted.
      - name: molecule
        uses: balling-dev/molecule-action@1.0.0
        with:
          image: ${{ matrix.config.image }}
          tag: ${{ matrix.config.tag }}
          command: "--debug test"
```
