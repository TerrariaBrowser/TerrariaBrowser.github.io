<template>
  <div class="card card-default facet">
    <div
      v-b-toggle="'collapse_' + aggregation.key"
      class="card-header"
    >
      <span class="icon"/>
      <span class="card-title small">{{ aggregation.name }}</span>
    </div>

    <b-collapse
      :id="'collapse_' + aggregation.key"
      :visible="!!aggregation.isRefined"
    >
      <ul class="list-group list-group-flush pre-scrollable">
        <li
          v-for="item in aggregation.items"
          :key="item.key"
          :class="{refined: item.refined}"
          :data-facet-key="aggregation.key"
          :data-facet-value="item.key"
          class="list-group-item d-flex justify-content-between align-items-center"
          @click="refine"
        >
          <div class="value small">{{ item.key }}</div>
          <span class="badge badge-secondary badge-pill">{{ item.doc_count }}</span>
        </li>
      </ul>
    </b-collapse>
  </div>
</template>

<script>
import bCollapse from 'bootstrap-vue/es/components/collapse/collapse';
import bToggle from 'bootstrap-vue/es/directives/toggle/toggle';

export default {
  components: {
    'b-collapse': bCollapse,
  },
  directives: {
    'b-toggle': bToggle,
  },
  props: {
    aggregation: {
      type: Object,
      required: true,
      default: () => {},
    },
  },
  methods: {
    refine(e) {
      this.$emit(
        'toggleFacet',
        e.currentTarget.dataset.facetKey,
        e.currentTarget.dataset.facetValue,
      );
    },
  },
};
</script>

<style lang="scss">
@import './Facet.scss'
</style>
