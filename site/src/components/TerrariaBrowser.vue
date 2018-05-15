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
      activeFacets: {},
      query: '',
      items: [],
      recipes: [],
    };
  },
  watch: {
    '$route.params': {
      immediate: true,
      handler(routeParams) {
        Object.keys(DB.facetMap).forEach((key) => {
          if (routeParams[key] && routeParams[key] !== '-') {
            this.activeFacets[key] = routeParams[key].split(',');
          } else {
            this.activeFacets[key] = null;
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
    jQuery.when(
      jQuery.getJSON('/static/items.json'),
      jQuery.getJSON('/static/recipes.json'),
    ).done((items, recipes) => {
      [this.items, this.recipes] = [items[0], recipes[0]];
      this.runSearch();
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
        if (this.activeFacets[key] && this.activeFacets[key].length) {
          params[key] = this.activeFacets[key].join(',');
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
      this.activeFacets[key] = this.activeFacets[key] || [];

      // If this value exists in the array, splice it out.
      const existingIndex = this.activeFacets[key].indexOf(value);
      if (existingIndex !== -1) {
        this.activeFacets[key].splice(existingIndex, 1);
      } else {
        // Otherwise push it in.
        this.activeFacets[key].push(value);
      }

      this.updateRoute();
    },
    runSearch() {
      const perPage = 30;
      // @TODO - pagination?!
      // const page = 1;

      // Run the JSON search in a promise to make it async. Should stop typing getting blocked.
      new Promise((resolve) => {
        // Convert our query to regex; Stragely, regex benchmarks faster than a string indexOf!
        const regexp = new RegExp(this.query, 'i');

        // Resolve this promise with the result of a reduce.
        resolve(this.items.reduce(
          (result, item) => {
            // Check if this item's name matches our regex. If not, bail early.
            if (!item.name.match(regexp)) {
              return result;
            }

            // Copy result to avoid the no-param-reassign lint errors.
            const newResult = result;

            // Process facet keys
            Object.keys(DB.facetMap).forEach((aggKey) => {
              // Does this itme have a value for this key?
              // @TODO - need to do this better...
              if (item[aggKey].length) {
                // Do we have an aggregation entry for it? If not, stub it.
                if (typeof newResult.aggregations[aggKey] === 'undefined') {
                  newResult.aggregations[aggKey] = {
                    key: aggKey,
                    buckets: [],
                    isRefined: !!this.activeFacets[aggKey] && this.activeFacets[aggKey].length,
                  };
                }

                const { buckets } = newResult.aggregations[aggKey];
                const bucketIndex = buckets.findIndex(i => i.key === item[aggKey]);
                if (bucketIndex !== -1) {
                  buckets[bucketIndex].doc_count += 1;
                } else {
                  let isRefined = false;
                  if (this.activeFacets[aggKey]) {
                    isRefined = this.activeFacets[aggKey].indexOf(item[aggKey]) !== -1;
                  }

                  buckets.push({
                    isRefined,
                    key: item[aggKey],
                    doc_count: 1,
                  });
                }
              }
            });

            // Deal with facets
            try {
              Object.keys(this.activeFacets).forEach((aggKey) => {
                // Skip if this facet is empty.
                if (this.activeFacets[aggKey] && this.activeFacets[aggKey].length) {
                  // Check if this items value for aggKey is one of the set facet values.
                  if (this.activeFacets[aggKey].indexOf(item[aggKey]) === -1) {
                    throw new Error('Not Found');
                  }
                }
              });
            } catch (err) {
              // If we catch an error here, bail out. We throw errors if a facet does not match.
              return newResult;
            }

            // It does, increment to total matches counter.
            newResult.hits.total += 1;

            // If we're within our perPage limit, push it to the hits.
            if (newResult.hits.hits.length < perPage) {
              const newItem = item;
              // @TODO - on create, create a map of itemid > name and vice versa

              // eslint-disable-next-line no-underscore-dangle
              newItem._crafted = this.recipes.filter(r => r.result === item.name);

              // eslint-disable-next-line no-underscore-dangle,arrow-body-style
              newItem._crafts = this.recipes.filter((r) => {
                return r.ingredients && (item.name in r.ingredients);
              });
              newResult.hits.hits.push(newItem);
            }

            // Return the modified results.
            return newResult;
          },
          // We setup the result set to mimick an elastic search. Should mean if we
          // want to change backends in the future, it might make it easier!
          { hits: { total: 0, hits: [] }, aggregations: {} },
        ));
      }).then((result) => {
        // Set hits.
        this.hits = result.hits;

        // Sort the buckets
        Object.keys(DB.facetMap).forEach((aggKey) => {
          if (result.aggregations[aggKey]) {
            result.aggregations[aggKey].buckets.sort((a, b) => b.doc_count - a.doc_count);
          }
        });
        // Set the aggregations
        this.aggregations = result.aggregations;
      });
    },
  },
};
</script>
