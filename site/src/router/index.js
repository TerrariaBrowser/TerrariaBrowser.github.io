import Vue from 'vue';
import Router from 'vue-router';
import TerrariaBrowser from '@/components/TerrariaBrowser';

Vue.use(Router);

// @TODO - expose facets here
const pathParams = ['query'].map(key => `:${key}?`).join('/');
export default new Router({
  routes: [
    {
      path: `/${pathParams}`,
      name: 'TerrariaBrowser',
      component: TerrariaBrowser,
      props: true,
    },
  ],
});
