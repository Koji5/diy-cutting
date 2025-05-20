// app/javascript/controllers/index.js
import { application }              from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// フォルダ配下をまとめて登録
eagerLoadControllersFrom("controllers", application)
