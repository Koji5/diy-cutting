// ------------------------------------------------------------
// Stimulus controller manifest
// ------------------------------------------------------------
//  ✓ importmap の論理名 "controllers/..." で読み込む
//  ✓ eagerLoadControllersFrom でフォルダ配下を自動登録

import { application }               from "controllers/application"
import { eagerLoadControllersFrom }  from "@hotwired/stimulus-loading"

// app/javascript/controllers 配下の *_controller.js をすべて登録
eagerLoadControllersFrom("controllers", application)

// もし個別に上書き登録したい場合は↓のように書けます
// import AddressController from "controllers/address_controller"
// application.register("address", AddressController)