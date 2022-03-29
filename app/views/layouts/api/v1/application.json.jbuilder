# frozen_string_literal: true

json.data JSON.parse(yield)

json.errors @errors
