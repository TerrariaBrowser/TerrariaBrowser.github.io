import Vue from 'vue';

import 'bootstrap';
// import { Tabs } from 'bootstrap-vue/es/components';
import BootstrapVue from 'bootstrap-vue';

import App from './App';
import router from './router';

Vue.config.productionTip = false;

Vue.use(BootstrapVue);


/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  render: h => h(App),
});
