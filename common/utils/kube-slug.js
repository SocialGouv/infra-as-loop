const { createHash } = require("crypto")

const KUBERNETS_MAX_NAME_LENGTH = 63
const SUFFIX_SHA_LENGTH = 8
const SLICE_LENGTH = KUBERNETS_MAX_NAME_LENGTH - SUFFIX_SHA_LENGTH

const suffix = (name) => {
  const hex = Buffer.from(
    createHash("sha256").update(name).digest("hex")
  ).toString()
  return parseInt(hex, 16).toString(36).slice(0, 6)
}

const slug = (name = "") => {
  let slugified = name.toLowerCase().replace(/[^a-z0-9-]/g, "")

  slugified = slugified.replace(/-+$/g, "").replace(/^-+/g, "")

  if (slugified.length > KUBERNETS_MAX_NAME_LENGTH || slugified !== name) {
    const shortSlug = slugified.slice(0, SLICE_LENGTH)
    slugified = `${shortSlug}${shortSlug.endsWith("-") ? "" : "-"}${suffix(
      name
    )}`
  }
  return slugified
}

module.exports = slug
