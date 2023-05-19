// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import "controllers"

import { Application } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

const application = Application.start()
const turbo = new Turbo()

