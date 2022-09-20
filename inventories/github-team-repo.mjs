#!/usr/bin/env zx

// import { $ } from "zx"
import yaml from "js-yaml"
import fs from "fs-extra"

const { TEAM_NAME } = process.env

const json = await fs.readFile(
  `data/github-teams/${TEAM_NAME}/github-repos.json`
)

const repos = JSON.parse(json)

const data = repos.map(({ name }) => ({
  REPOSITORY_NAME: name,
}))

const output = yaml.dump(data)

process.stdout.write(output)
