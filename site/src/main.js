import Vue from 'vue';
import PouchDB from 'pouchdb-browser';
import PouchDBFind from 'pouchdb-find';
import PouchDBLiveFind from 'pouchdb-live-find';

import App from './App';
import router from './router';

PouchDB.plugin(PouchDBFind);
PouchDB.plugin(PouchDBLiveFind);

Vue.use(require('vue-pouch'), {
  pouch: PouchDB,
  defaultDB: 'config',
});


Vue.config.productionTip = false;

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  render: h => h(App),
});
