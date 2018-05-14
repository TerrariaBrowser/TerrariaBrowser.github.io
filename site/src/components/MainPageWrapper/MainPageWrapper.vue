<template>
  <div id="page-content-wrapper">
    <div class="container-fluid">
      <div class="row">
        <div class="col">
          <h3 class="text-muted">Terraria Recipe &amp; Item Browser</h3>
        </div>
      </div>
      <div class="row">
        <p v-if="hits === null">
          Lets do a search!
        </p>
        <Result
          v-for="hit in hits.hits"
          v-else
          :hit="hit"
          :key="hit.itemid"
        />
        <Spinner v-if="searchInProgress" />
        <div id="pager" />
      </div>
    </div>
  </div>
</template>

<script>
import Result from './Result/Result';
import Spinner from './Spinner/Spinner';

export default {
  components: {
    Result,
    Spinner,
  },
  props: {
    hits: { type: Object, default: () => {} },
    searchInProgress: { type: Boolean, required: true },
  },
};
</script>

<style lang="scss">
@import './MainPageWrapper.scss'
</style>
