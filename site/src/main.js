import 'bootstrap';
import Vue from 'vue';
import BootstrapVue from 'bootstrap-vue';
import VueResource from 'vue-resource';

import App from './App';
import store from './store';
import router from './router';

Vue.config.productionTip = false;
Vue.use(BootstrapVue);
Vue.use(VueResource);

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  render: h => h(App),
});
