import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    items: [],
    recipes: [],
    facetMap: {
      type: { title: 'Type' },
      damagetype: { title: 'Damage Type' },
    },
  },
  mutations: {
    FETCH_ITEMS(state, items) {
      state.items = items;
    },
    FETCH_RECIPES(state, recipes) {
      state.recipes = recipes;
    },
  },
  actions: {
    fetchItems({ commit }) {
      return Vue.http
        .get('/static/items.json')
        .then((response) => { commit('FETCH_ITEMS', response.body); })
        .catch((error) => { console.error(error.statusText); }); // eslint-disable-line no-console
    },
    fetchRecipes({ commit }) {
      return Vue.http
        .get('/static/recipes.json')
        .then((response) => { commit('FETCH_RECIPES', response.body); })
        .catch((error) => { console.error(error.statusText); }); // eslint-disable-line no-console
    },
  },
  getters: {
    getItemByName: state => name => state.items.find(item => item.name === name),
  },
});

export default store;
