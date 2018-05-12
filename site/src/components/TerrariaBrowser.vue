<template>
  <div
    id="wrapper"
    :class="{ sidebarToggled: sidebarExpanded }"
  >
    <Sidebar
      :aggregations="aggregations"
      :query="query"
      @toggleSidebar="toggleSidebar"
      @runSearch="updateQuery"
      @toggleFacet="toggleFacet"
    />
    <MainPageWrapper
      :hits="hits"
      :search-in-progress="searchInProgress"
    />
  </div>
</template>

<script>
import jQuery from 'jquery';
import PouchDB from 'pouchdb-browser';

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
      hits: [],
      aggregations: null,
      page: 0,
      loadMoreEnabled: false,
      searchInProgress: false,
      query: '',
      itemsDb: new PouchDB('items'),
    };
  },
  watch: {
    '$route.params': {
      immediate: true,
      handler(routeParams) {
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
          this.query = undefined;
        } else {
          this.query = routeParams.query;
        }

        this.page = 0;
        this.searchInProgress = true;

        this.runSearch();

        this.searchInProgress = false;
      },
    },
  },
  created() {
    PouchDB.debug.enable('pouchdb:find');

    this.itemsDb.info().then((result) => {
      if (result.doc_count === 0) {
        this.itemsDb.createIndex({ index: { fields: ['name'] } });

        jQuery.getJSON('/static/items.json')
          .done((data) => {
            this.itemsDb.bulkDocs(data);
          });
      }
    });
  },
  methods: {
    loadMore() {
      if (this.loadMoreEnabled && !this.searchInProgress) {
        this.page += 1;
        this.searchInProgress = true;

        this.runSearch();
      }
    },
    toggleSidebar() {
      this.sidebarExpanded = !this.sidebarExpanded;
    },
    updateQuery(query) {
      this.query = query;
      this.updateRoute();
    },
    updateRoute() {
      // Params starts with query.
      const params = { query: this.query };
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
      // this.itemsDb.getIndexes().then(result => console.log('INDEXES', result));
      const regexp = new RegExp(this.query, 'i');

      this.itemsDb.find({
        selector: {
          $and: [
            { name: { $gt: null } },
            { name: { $regex: regexp } },
          ],
        },
        limit: 24,
        sort: [{ name: 'asc' }],
      }).then((result) => {
        // eslint-disable-next-line no-console
        console.log('QUERY RESULT', result);
        this.hits = result.docs;
      }).catch((err) => {
        // eslint-disable-next-line no-console
        console.error(err);
      });
    },
  },
};
</script>
