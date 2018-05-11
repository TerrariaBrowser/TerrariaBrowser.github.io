<template>
  <div id="wrapper" v-bind:class="{ sidebarToggled: sidebarExpanded }">
    <Sidebar
      v-on:toggleSidebar="toggleSidebar"
      v-on:runSearch="updateQuery"
      v-on:toggleFacet="toggleFacet"
      :aggregations="aggregations"
      />
    <MainPageWrapper :hits="hits" :searchInProgress="searchInProgress" />
  </div>
</template>

<script>
import jQuery from 'jquery';
import Sidebar from '@/components/Sidebar/Sidebar';
import MainPageWrapper from '@/components/MainPageWrapper/MainPageWrapper';
import DB from '@/db';

export default {
  components: {
    Sidebar,
    MainPageWrapper,
  },
  data() {
    return {
      sidebarExpanded: false,
      hits: null,
      aggregations: null,
      page: 0,
      loadMoreEnabled: false,
      searchInProgress: false,
      items: [],
    };
  },
  created() {
    jQuery.getJSON('/static/items.json')
      .done((data) => {
        console.log(data);
        this.items = data
      });
  },
  methods: {
    loadMore() {
      if (this.loadMoreEnabled && !this.searchInProgress) {
        this.page += 1;
        this.searchInProgress = true;

        // this.hits = this.items.filter(item => item.name.toLowerCase().includes(DB.query))
        this.runSearch();

        // DB.search(this.page)
        //   .then((response) => {
        //     this.hits.push(...response.hits.hits);
        //     this.aggregations = response.aggregations;
        //     this.loadMoreEnabled = (DB.pageLength === response.hits.hits.length);
        //   })
        //   .finally(() => { this.searchInProgress = false; });
      }
    },
    toggleSidebar() {
      this.sidebarExpanded = !this.sidebarExpanded;
    },
    updateQuery(query) {
      DB.query = query;
      this.updateRoute();
    },
    updateRoute() {
      // Params starts with query.
      const params = { query: DB.query };
      if (params.query === undefined || params.query.length === 0) {
        params.query = '-';
      }

      // Now add a param for each of the facetMap. Each param will be at least '-'.
      Object.keys(DB.facetMap).forEach((key) => {
        params[key] = '-';
        if (DB.activeFacets[key] && DB.activeFacets[key].length) {
          params[key] = DB.activeFacets[key].join(',');
        }
      });

      // Strip any trailing - placeholders from the URL
      ['query', ...Object.keys(DB.facetMap)].reverse().some((key) => {
        if (params[key] === '-') {
          // Remove key
          delete params[key];
          return false;
        }
        return true;
      });

      // Set the route. This event will cause the properties on this component to get set via the
      // router. This triggers the watched route params.
      this.$router.push({
        name: 'TerrariaBrowser',
        params,
      });
    },
    toggleFacet(key, value) {
      DB.activeFacets[key] = DB.activeFacets[key] || [];

      // If this value exists in the array, splice it out.
      const existingIndex = DB.activeFacets[key].indexOf(value);
      if (existingIndex !== -1) {
        DB.activeFacets[key].splice(existingIndex, 1);
      } else {
        // Otherwise push it in.
        DB.activeFacets[key].push(value);
      }

      this.updateRoute();
    },
    runSearch() {
      this.hits = this.items.filter(item => item.name.toLowerCase().includes(DB.query.toLowerCase()));
    },
  },
  watch: {
    items () {
      this.runSearch();
    },
    '$route.params': {
      immediate: true,
      handler(routeParams) {
        console.log('UPDATED');
        Object.keys(DB.facetMap).forEach((key) => {
          if (routeParams[key] && routeParams[key] !== '-') {
            DB.activeFacets[key] = routeParams[key].split(',');
          } else {
            DB.activeFacets[key] = null;
          }
        });

        if (routeParams.query === undefined ||
            routeParams.query.length === 0 ||
            routeParams.query === '-') {
          DB.query = undefined;
        } else {
          DB.query = routeParams.query;
        }

        this.page = 0;
        this.searchInProgress = true;

        this.runSearch();

        this.searchInProgress = false;

        // DB.search(0)
        //   .then((response) => {
        //     this.hits = response.hits.hits;
        //     this.aggregations = response.aggregations;
        //     this.loadMoreEnabled = (DB.pageLength === response.hits.hits.length);
        //   })
        //   .finally(() => { this.searchInProgress = false; });
      },
    },
  },
};
</script>
