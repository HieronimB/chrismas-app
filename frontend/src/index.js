'use strict';

require("./styles.scss");
require("./fallingsnow_v6");
const {Elm} = require('./Main');
var app = Elm.Main.init({flags: 4,
    node: document.getElementById('elm')
});
