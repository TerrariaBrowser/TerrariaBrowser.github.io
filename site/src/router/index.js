import Vue from 'vue';
import Router from 'vue-router';
import TerrariaBrowser from '@/components/TerrariaBrowser';
import store from '@/store';

Vue.use(Router);

// @TODO - expose facets here
const queryParams = ['query'].concat(Object.keys(store.state.facetMap)).map(key => `:${key}?`).join('/');
export default new Router({
  routes: [
    {
      path: `/${queryParams}`,
      name: 'TerrariaBrowser',
      component: TerrariaBrowser,
      props: true,
    },
  ],
});
