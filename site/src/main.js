import Vue from 'vue';

import PouchDB from 'pouchdb-browser';
import PouchDBFind from 'pouchdb-find';

import App from './App';
import router from './router';

PouchDB.plugin(PouchDBFind);

Vue.config.productionTip = false;

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  render: h => h(App),
});
