const functions = require("firebase-functions");
const admin = require('firebase-admin')
const nodemailer = require('nodemailer')
const cors = require('cors')({origin:true})
admin.initializeApp();




/**
* Here we're using Gmail to send 
*/
/*
   1. We need a gmail account with Two Factor Authentication (2FA)
    --> check it under your account information
   2. Enable IMAP (Individual Mailbox Side)
    --> inside your mail options, select the "Forwarding POP/IMAP" tab and check IMAP ACCESS to enable it
        (SAVE IT)
   3. Create an App Password 
    --> enter in the Security option of you google account
        --> select "2-Step Verification" and scroll down to "App Password"
        --> generate an app password to use


let transporter = nodemailer.createTransport({
    service: 'gmail',
    secureConnection:true,
    debug:true,
    auth: {
        user: 'sciamanna.roberto@gmail.com',
        pass: 'sctegsrgeuchybsn'
    }
});
*/

// const { email = "sciamanna.roberto@gmail.com", password = "sctegsrgeuchybsn" } = functions.config().gmail || {};
const { email = "bufalabuona@gmail.com", password ="txzbhetjibbceqew"} = functions.config().gmail || {};
const transporter = nodemailer.createTransport(
  `smtps://${email}:${password}@smtp.gmail.com`
);

exports.sendMail = functions.https.onRequest((req, res) => {
    cors(req, res, () => {
        // get message from request body
        const message = req.body.message;
        // getting dest email by query string
        const dest = req.body.dest;
        const subject = req.body.subject;

        const mailOptions = {
            from: 'Bufala Buona <no-reply@bufalabuona.it>', // Something like: Jane Doe <janedoe@gmail.com>
            to: dest,
            text: 'MESSAGGIO NON HTML',
            subject: subject, // email subject
            html: `<p style="font-size: 16px;">${message}</p>`
             // email content in HTML
        };
  
        // returning result
        return transporter.sendMail(mailOptions, (erro, info) => {
            if(erro){
                return res.send(erro.toString());
            }
            return res.send('Sended');
        });
    });    
});
