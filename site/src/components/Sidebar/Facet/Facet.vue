<template>
  <div class="card card-default facet">
    <div
      v-b-toggle="'collapse_' + aggregation.key"
      class="card-header px-3 py-2"
    >
      <span class="icon"/>
      <span class="card-title small">{{ title }}</span>
    </div>

    <b-collapse
      :id="'collapse_' + aggregation.key"
      :visible="!!aggregation.isRefined"
      class="pre-scrollable"
    >
      <ul class="list-group list-group-flush">
        <li
          v-for="bucket in aggregation.buckets"
          :key="bucket.key"
          :class="{refined: bucket.isRefined}"
          :data-facet-key="aggregation.key"
          :data-facet-value="bucket.key"
          class="list-group-item d-flex justify-content-between align-items-center px-3 py-2"
          @click="refine"
        >
          <div class="value small">{{ bucket.key }}</div>
          <span class="badge badge-secondary badge-pill">{{ bucket.doc_count }}</span>
        </li>
      </ul>
    </b-collapse>
  </div>
</template>

<script>
export default {
  props: {
    aggregation: {
      type: Object,
      required: true,
      default: () => {},
    },
  },
  computed: {
    title() {
      return this.$store.state.facetMap[this.aggregation.key].title;
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
