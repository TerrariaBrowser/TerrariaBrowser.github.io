<template>
  <div class="resultWrapper">
    <div class="result p-3 mb-4">
      <img
        v-if="hit.itemid > 0"
        :src="imageSrc"
        class="float-right">

      <h4>{{ hit.name }}</h4>

      <b-tabs
        small
        lazy>
        <b-tab
          title="Overview"
          title-link-class="px-2 py-1"
          active>
          <b-table
            :items="overviewAttributes"
            striped
            hover
            small
            class="small">
            <span
              slot="value"
              slot-scope="data"
              v-html="data.value" />
          </b-table>
        </b-tab>

        <b-tab
          v-if="hit._crafts.length"
          title="Makes"
          title-link-class="px-2 py-1">
          <div
            v-for="(group, section) of groupedMakes"
            :key="section">
            <h4 class="mt-5">
              {{ group.title }}
              <img
                v-if="group.stationItem"
                :src="group.stationImage"
                class="float-right">
            </h4>
            <Recipe
              v-for="recipe of group.items"
              :recipe="recipe"
              :key="recipe.id" />
          </div>
        </b-tab>

        <b-tab
          v-if="hit._crafted.length"
          title="Made From"
          title-link-class="px-2 py-1">
          <Recipe
            v-for="recipe of hit._crafted"
            :recipe="recipe"
            :show-title="false"
            :key="recipe.id" />
        </b-tab>
      </b-tabs>
    </div>
  </div>
</template>

<script>
import sanitizeHtml from 'sanitize-html';
import Recipe from './Recipe/Recipe';

export default {
  filters: {
    formatLongNumber(number) {
      const decimalPlaces = 1;
      const base = Math.floor(Math.log(Math.abs(number)) / Math.log(1000));
      const suffix = 'kmbt'[base - 1];
      return suffix ? (number / (1000 ** base)).toFixed(decimalPlaces) + suffix : number;
    },
  },
  components: {
    Recipe,
  },
  props: {
    hit: { type: Object, required: true, default: () => {} },
  },
  computed: {
    imageSrc() { return `/static/images/items/Item_${this.hit.itemid}.png`; },
    groupedMakes() {
      // eslint-disable-next-line no-underscore-dangle
      return this.hit._crafts.reduce((ret, recipe) => {
        const retCopy = ret;

        if (retCopy[recipe.station] === undefined) {
          const title = recipe.station.replace(/_/g, ' ');
          const stationItem = this.stationItem(title);
          const stationImage = stationItem ? `/static/images/items/Item_${stationItem.itemid}.png` : false;
          retCopy[recipe.station] = {
            title,
            stationItem,
            stationImage,
            items: [],
          };
        }

        retCopy[recipe.station].items.push(recipe);
        return retCopy;
      }, {});
    },
    overviewAttributes() {
      return Object.keys(this.hit).reduce((ret, attribute) => {
        // Hard-Skip these fields. (at lest for now!)
        if (attribute === 'name' || attribute === 'sellvalue' || attribute === 'buyvalue' || attribute.indexOf('_') === 0) return ret;

        // Skip empty items.
        if (this.hit[attribute] === null || this.hit[attribute].length === 0) return ret;

        let value = this.hit[attribute];
        switch (attribute) {
          case 'tooltip':
            value = sanitizeHtml(value, { allowedTags: ['br'], allowedAttributes: [] });
            break;
          default:
            value = sanitizeHtml(value, { allowedTags: [], allowedAttributes: [] });
        }

        ret.push({
          attribute,
          value,
        });
        return ret;
      }, []);
    },
  },
  methods: {
    stationItem(stationName) {
      return this.$store.getters.getItemByName(stationName);
    },
  },
};
</script>

<style lang="scss">
@import './Result.scss'
</style>
