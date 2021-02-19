import Vue from 'vue'
import App from './App.vue'
import './assets/tailwind.css'
import Amplify, { Auth } from 'aws-amplify'
import '@aws-amplify/ui-vue'

Amplify.configure({
  Auth: {
    region: process.env.VUE_APP_AWS_REGION,
    userPoolId: process.env.VUE_APP_USER_POOL_ID,
    userPoolWebClientId: process.env.VUE_APP_WEB_COGNITO_USER_POOL_CLIENT_ID,
    mandatorySignIn: true
  }
})

Auth.configure();

const myAppConfig = {
  'aws_appsync_graphqlEndpoint': process.env.VUE_APP_AWS_APPSYNC_GRAPHQL_ENDPOINT,
  'aws_appsync_region': process.env.VUE_APP_AWS_REGION,
  'aws_appsync_authenticationType': 'AMAZON_COGNITO_USER_POOLS'
}

Amplify.configure(myAppConfig);

Vue.config.productionTip = false

new Vue({
  render: h => h(App),
}).$mount('#app')
