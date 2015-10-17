#!/usr/bin/env node
'use strict';

var config = {
    nodeIp: '127.0.0.1',
    nodePort: 3000,
    dbHost: '127.0.0.1',
    dbPort: '3306',
    dbUser: 'root',
    dbPassword: 'mysql',
    sessionSecret: 'sessionSecret'
};

// database connection
var mysql = require('mysql');
var jimp = require('jimp');
var connection = mysql.createConnection({
    host: config.dbHost,
    port: config.dbPort,
    user: config.dbUser,
    password: config.dbPassword
});
connection.connect();

var express = require('express');
var app = express();

var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

// parse file uploads
var multer = require('multer');
app.use(multer({
    inMemory: true,
    includeEmptyFields: true
}));

// authentication stuff
var passport = require('passport'),
    LocalStrategy = require('passport-local').Strategy,
    cookieParser = require('cookie-parser'),
    session = require('express-session'),
    bcrypt = require('bcrypt-nodejs');

// TODO change connection to https
// Because we are hosting the app in openshift, https certification is handled by it automatically

passport.use(new LocalStrategy(
    function (username, password, done) {
        connection.query('select password_hash from tucha.user where username=' + mysql.escape(username), function (err, rows) {
            if (err) {
                return done(err);
            } else if (rows.length === 0) {
                return done(null, false);
            } else if (bcrypt.compareSync(password, rows[0].password_hash)) {
                return done(null, {username: username, password: password});
            } else {
                return done(null, false);
            }
        });
    }
));
passport.serializeUser(function (user, done) {
    done(null, user);
});
passport.deserializeUser(function (user, done) {
    done(null, user);
});
app.use(express.static('public'));
app.use(cookieParser());
app.use(bodyParser());
app.use(session({secret: config.sessionSecret}));
app.use(passport.initialize());
app.use(passport.session());

app.post('/r/login',
    passport.authenticate('local', {
        successRedirect: '/',
        failureRedirect: '/#/login',
        failureFlash: true
    })
);

app.get('/r/logout', function (req, res) {
    req.logout();
    res.redirect('/#/login');
});

function auth(req, res, next) {
    if (!req.isAuthenticated()) {
        res.send(401);
    } else {
        next();
    }
}

function query(sql, res) {
    console.log(sql);
    connection.query(sql, function (err, rows) {
        if (err) {
            console.log(err);
            return;
        }
        res.json(rows);
    });
}

function logQueryError(err) {
    if (err) {
        console.log(err);
    }
}

function storeImage(id, buffer, callback) {
    new jimp(buffer, function (err, image) {
        var w = image.bitmap.width,
            h = image.bitmap.height,
            pictureRatio = 800 / w,
            pw = w * pictureRatio,
            ph = h * pictureRatio,
            thumbnailRatio = 50 / w,
            tw = w * thumbnailRatio,
            th = h * thumbnailRatio;

        image.resize(pw, ph)
            .getBuffer(jimp.MIME_JPEG, function (err, resizedBuffer) {
                var sql = 'update tucha.animal set picture=? where id=' + id;
                sql = mysql.format(sql, [resizedBuffer]);

                connection.query(sql, logQueryError);
            });

        image.resize(tw, th)
            .getBuffer(jimp.MIME_JPEG, function (err, resizedBuffer) {
                var sql = 'update tucha.animal set picture_thumbnail=? where id=' + id;
                sql = mysql.format(sql, [resizedBuffer]);

                connection.query(sql, function (err) {
                    logQueryError(err);
                    if (typeof callback !== 'undefined') {
                        callback();
                    }
                });
            });
    });
}

function saveState(state) {
    connection.query('select * from tucha.state where position=' + state.position + ' and animal=' + state.animal,
        function (err, rows) {
            var sql;

            if (err || rows.length === 0) {
                sql = 'insert into tucha.state set ?';
            } else if (rows.length > 0) {
                sql = 'update tucha.state set ? where position=' + state.position + ' and animal=' + state.animal;
            }

            connection.query(sql, state, logQueryError);
        });
}

var selects = {
    animal: {
        entity: 'animal',
        details: 'select id, code, name, species, gender, breed, date_of_birth, size, color,' +
        ' details, is_adoptable, is_adoptable_reason, received_by, received_from, received_date,' +
        ' received_details, chip_code, is_sterilizated, sterilization_date, sterilization_by, sterilization_details,' +
        ' current_situation, missing_details, death_date, death_reason' +
        ' from tucha.animal where is_deleted is null',
        dropdown: 'select id, name from tucha.animal where is_deleted is null',
        adoptableAnimals: 'select id,name,gender from tucha.animal where is_adoptable=true and ' +
        '(current_situation="IN_SHELTER" or current_situation="FAT" or current_situation="FAR") and ' +
        'picture_thumbnail is not null and is_deleted is null'
    },
    veterinary: {
        entity: 'veterinary',
        details: 'select id, name, address, details from tucha.veterinary where is_deleted is null',
        dropdown: 'select id, name from tucha.veterinary where is_deleted is null'
    },
    person: {
        entity: 'person',
        details: 'select id, name, address, city, phone, email, new_adoption_allowed, details, can_host, host_capacity, ' +
        'host_species, host_details from tucha.person where is_deleted is null',
        dropdown: 'select id, name from tucha.person where is_deleted is null'
    },
    user: {
        entity: 'user',
        details: 'select username, role, person from tucha.user where is_deleted is null'
    },
    medicalExam: {
        entity: 'medical_exam',
        details: 'select id, animal, date, veterinary, details from tucha.medical_exam where is_deleted is null'
    },
    vaccination: {
        entity: 'vaccination',
        details: 'select id, animal, date, veterinary, details from tucha.vaccination where is_deleted is null'
    },
    deparasitation: {
        entity: 'deparasitation',
        details: 'select id, animal, date, veterinary, details from tucha.deparasitation where is_deleted is null'
    },
    medicalTreatment: {
        entity: 'medical_treatment',
        details: 'select id, animal, date, veterinary, details from tucha.medical_treatment where is_deleted is null'
    },
    medicamentPrescription: {
        entity: 'medicament_prescription',
        details: 'select id, animal, date, veterinary, details from tucha.medicament_prescription where is_deleted is null'
    },
    aggressivityReport: {
        entity: 'aggressivity_report',
        details: 'select id, animal, date, reported_by, details from tucha.aggressivity_report where is_deleted is null'
    },
    escapeReport: {
        entity: 'escape_report',
        details: 'select id, animal, date, details, returned_date from tucha.escape_report where is_deleted is null'
    },
    adoption: {
        entity: 'adoption',
        details: 'select id, animal, date, details, adoptant from tucha.adoption where is_deleted is null'
    },
    medicament: {
        entity: 'medicament',
        details: 'select id, name, details from tucha.medicament where is_deleted is null',
        dropdown: 'select id, name from tucha.medicament where is_deleted is null'
    },
    supplier: {
        entity: 'supplier',
        details: 'select id, name, address, phone, email, details from tucha.supplier where is_deleted is null',
        dropdown: 'select id, name from tucha.supplier where is_deleted is null'
    },
    donation: {
        entity: 'donation',
        details: 'select id, details, donated_by from tucha.donation where is_deleted is null'
    },
    medicamentUnit: {
        entity: 'medicament_unit ',
        details: 'select id, medicament, details, used, used_in, opening_date, expiration_date, bought_in, ' +
        'bought_by, donated_by, acquired_date, unitary_price, initial_quantity, remaining_quantity ' +
        'from tucha.medicament_unit where is_deleted is null'
    },
    devolution: {
        entity: 'devolution',
        details: 'select id, animal, adoptant, reason, date from tucha.devolution where is_deleted is null'
    },
    medicamentUsed: {
        entity: 'medicament_used',
        details: 'select id, medicament, animal, administrator, prescription, date, quantity ' +
        'from tucha.medicament_used where is_deleted is null'
    },
    medicamentSupplier: {
        entity: 'medicament_supplier',
        details: 'select supplier, medicament from tucha.medicament_supplier where is_deleted is null'
    },
    volunteer: {
        entity: 'volunteer',
        details: 'select id, person, disponibility, activities, expertises, connections ' +
        'from tucha.volunteer where is_deleted is null'
    },
    host: {
        entity: 'host',
        details: 'select id, animal, person, start_date, end_date, details from tucha.host where is_deleted is null'
    },
    state: {
        entity: 'state',
        details: 'select id, animal, date, details, position from tucha.state where is_deleted is null'
    }
};

// data for slider
app.get('/r/adoptableAnimals', function (req, res) { // used in the slider, must no check authentication
    query(selects[req.params.entity].adoptableAnimals, res);
});

// get grid
app.get('/r/:entity', auth, function (req, res) {
    query(selects[req.params.entity].details, res);
});

// get dropdown data
app.get('/r/dropdown/:entity', auth, function (req, res) {
    query(selects[req.params.entity].dropdown, res);
});

// get details
app.get('/r/:entity/:id', auth, function (req, res) {
    var sql = selects[req.params.entity].details + ' and id=' + mysql.escape(req.params.id);
    console.log(sql);
    connection.query(sql, function (err, rows) {
        if (err) {
            console.log(err);
            return;
        }
        res.json(rows[0]);
    });
});

// save details
app.post('/r/:entity/:id', auth, function (req, res) {
    var sql, entity = selects[req.params.entity].entity, data = req.body, states = null;

    if (req.params.id === 'new') {
        sql = 'insert into tucha.' + entity + ' set ?';
    } else {
        sql = 'update tucha.' + entity + ' set ? where id=' + mysql.escape(req.params.id);
    }

    if (entity === 'animal') {
        states = data.states;
        delete data.states;
    }

    console.log(sql, data);
    connection.query(sql, data, function (err, result) {
        if (err) {
            console.log(err);
            return;
        }

        var id = req.params.id === 'new' ? result.insertId : req.params.id;

        if (entity === 'animal') {
            for (var i = 0; i < states.length; i++) {
                states[i].animal = id;
                saveState(states[i]);
            }
        }
        res.end(id + '');
    });
});

// save details
app.delete('/r/:entity/:id', auth, function (req, res) {
    query('update tucha.' + selects[req.params.entity].entity + ' set is_deleted=true where id=' + mysql.escape(req.params.id), res);
});

var emptyImage = new Buffer('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7', 'base64'); // 1px gif
app.get('/r/animal/:id/picture', auth, function (req, res) {
    connection.query('select picture from tucha.animal where id=' + req.params.id, function (err, rows) {
        if (err || rows.length === 0 || rows[0].picture === null) {
            res.writeHead(200, {'Content-Type': 'image/gif'});
            res.end(emptyImage);
        } else if (rows.length > 0) {
            res.writeHead(200, {'Content-Type': 'image/jpeg'});
            res.end(rows[0].picture, 'binary');
        }
    });
});

app.post('/r/animal/:id/picture', auth, function (req, res) {
    // store uploaded image
    if (typeof req.files.file !== 'undefined') { // image upload
        storeImage(mysql.escape(req.params.id), req.files.file.buffer, function () {
            res.end();
        });
    } else {
        res.end();
    }
});

app.get('/r/animal/:id/thumbnail', auth, function (req, res) {
    connection.query('select picture_thumbnail from tucha.animal where id=' + req.params.id, function (err, rows) {
        if (err || rows.length === 0 || rows[0].picture_thumbnail === null) {
            res.writeHead(200, {'Content-Type': 'image/gif'});
            res.end(emptyImage);
        } else if (rows.length > 0) {
            res.writeHead(200, {'Content-Type': 'image/jpeg'});
            res.end(rows[0].picture_thumbnail, 'binary');
        }
    });
});

app.get('/r/animal/:id/states', auth, function (req, res) {
    query('select date, details, position from tucha.state where animal=' + req.params.id +
        ' order by position asc', res);
});

app.post('/r/changePassword', auth, function (req, res) {
    query('update tucha.user set password_hash=\'' + bcrypt.hashSync(req.body.password, bcrypt.genSaltSync(8), null) +
        '\' where username=' + mysql.escape(req.user.username), res);
});

app.listen(config.nodePort, config.nodeIp);
