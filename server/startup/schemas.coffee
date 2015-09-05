# Schema =
# 	User: new SimpleSchema
# 		username: {
# 			type: String,
# 			regEx: /^[a-z0-9A-Z_]{3,15}$/
# 		},
# 		emails: {
# 			type: [Object],
# 			// this must be optional if you also use other login services like facebook,
# 			// but if you use only accounts-password, then it can be required
# 			optional: true
# 		},
# 		"emails.$.address": {
# 			type: String,
# 			regEx: SimpleSchema.RegEx.Email
# 		},
# 		"emails.$.verified": {
# 			type: Boolean
# 		},
# 		createdAt: {
# 			type: Date
# 		},
# 		profile: {
# 			type: Schema.UserProfile,
# 			optional: true
# 		},
# 		services: {
# 			type: Object,
# 			optional: true,
# 			blackbox: true
# 		},