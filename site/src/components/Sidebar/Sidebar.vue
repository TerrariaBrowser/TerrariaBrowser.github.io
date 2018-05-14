<template>
  <div id="sidebar-wrapper">
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-2">
          <a
            id="menu-toggle"
            @click="toggleSidebar"
          >
            <i
              class="fa fa-bars"
              aria-hidden="true"
            />
          </a>
        </div>
        <div class="col-sm-10">
          <div class="form-group">
            <div class="input-group">
              <div class="input-group-prepend">
                <span
                  id="basic-addon1"
                  class="input-group-text"
                >
                  <i
                    class="fa fa-search"
                    aria-hidden="true"
                  />
                </span>
              </div>
              <input
                v-model="mutableQuery"
                type="search"
                class="form-control"
                placeholder="Search"
                @input="runSearch"
              >
            </div>
          </div>

          <div id="searchSummary" />
          <div id="searchFacets">
            <Facet
              v-for="aggregation in aggregations"
              :aggregation="aggregation"
              :key="aggregation.id"
              @toggleFacet="toggleFacet"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import _debounce from 'lodash/debounce';
import Facet from './Facet/Facet';

export default {
  components: {
    Facet,
  },
  props: {
    query: { type: String, default: '' },
    aggregations: { type: Object, default: () => {} },
  },
  data() {
    return {
      mutableQuery: this.query,
    };
  },
  computed: {
    runSearch() {
      return _debounce(function inputCaptured(e) {
        this.$emit('runSearch', e.srcElement.value);
      }, 50).bind(this);
    },
  },
  methods: {
    toggleSidebar() {
      this.$emit('toggleSidebar');
    },
    toggleFacet(key, value) {
      this.$emit('toggleFacet', key, value);
    },
  },
};
</script>

<style lang="scss">
@import './Sidebar.scss';
</style>
