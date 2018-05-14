<template>
  <div class="resultWrapper">
    <div class="result p-3 mb-2">
      <p
        v-if="hit.itemid > 0"
        class="float-right"><img :src="imageSrc"></p>

      <h3>{{ hit.name }}</h3>

      <b-tabs small>
        <b-tab
          title="Overview"
          title-link-class="px-2 py-1"
          active>
          <b-table
            :items="overviewAttributes"
            striped
            hover
            small
            class="small" />
        </b-tab>

        <b-tab
          title="Crafting"
          title-link-class="px-2 py-1">
          <p>Crafting</p>
        </b-tab>

        <b-tab
          title="Crafted"
          title-link-class="px-2 py-1">
          <p>Crafted</p>
        </b-tab>
      </b-tabs>
    </div>
  </div>
</template>

<script>
export default {
  filters: {
    formatLongNumber(number) {
      const decimalPlaces = 1;
      const base = Math.floor(Math.log(Math.abs(number)) / Math.log(1000));
      const suffix = 'kmbt'[base - 1];
      return suffix ? (number / (1000 ** base)).toFixed(decimalPlaces) + suffix : number;
    },
  },
  props: {
    hit: { type: Object, required: true, default: () => {} },
  },
  computed: {
    imageSrc() {
      return `/static/images/items/Item_${this.hit.itemid}.png`;
    },
    overviewAttributes() {
      return Object.keys(this.hit).reduce((ret, key) => {
        // Hard-Skip these fields. (at lest for now!)
        if (key === 'name' || key === 'sellvalue' || key === 'buyvalue') return ret;

        // Skip empty items.
        if (this.hit[key] === null || this.hit[key].length === 0) return ret;

        // @TODO - tooltop contains HTML...
        ret.push({
          attribute: key,
          value: this.hit[key],
        });
        return ret;
      }, []);
    },
  },
};
</script>

<style lang="scss">
@import './Result.scss'
</style>
