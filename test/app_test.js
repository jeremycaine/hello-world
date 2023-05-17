process.env.NODE_ENV = 'test';

const chai = require('chai');
const chaiHttp = require('chai-http');
const my_test_server = require('../server');
const should = chai.should();

chai.use(chaiHttp);

describe('Basic routes tests', () => {

    it('GET to / should return 200', (done) => {
        chai.request(my_test_server)
            .get('/')
            .end((err, res) => {
                res.should.have.status(200);
            done();
        })

    })
})