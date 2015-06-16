$(function () {
 $("#up_btn").on('click', function (e) {
   e.preventDefault();
  $("#up_select").on('click', function (e) {
   e.preventDefault();
 });});
 formatFileSize = function (bytes) {
        if (typeof bytes !== 'number') {
            return '';
        }
        if (bytes >= 1000000000) {
            return (bytes / 1000000000).toFixed(2) + ' GB';
        }
        if (bytes >= 1000000) {
            return (bytes / 1000000).toFixed(2) + ' MB';
        }
        return (bytes / 1000).toFixed(2) + ' KB';
    }

    formatBitrate =  function (bits) {
        if (typeof bits !== 'number') {
            return '';
        }
        if (bits >= 1000000000) {
            return (bits / 1000000000).toFixed(2) + ' Gbit/s';
        }
        if (bits >= 1000000) {
            return (bits / 1000000).toFixed(2) + ' Mbit/s';
        }
        if (bits >= 1000) {
            return (bits / 1000).toFixed(2) + ' kbit/s';
        }
        return bits.toFixed(2) + ' bit/s';
    }

    formatFilename =  function (name) {
      if (name.length > 18 ) {
        return '....' + String(name).slice(-18);
      }else{
        return name;
       } 
    }
    formatDay = function(){
      var today = new Date();
      var dd = today.getDate();
      var mm = today.getMonth()+1; //January is 0!
      var yyyy = today.getFullYear();
      var hour = today.getHours();
      var minute = today.getMinutes();
      if(dd<10) {
        dd='0'+dd;
      } 

      if(mm<10) {
        mm='0'+mm;
      } 

      return   yyyy + '/' + mm+'/'+dd+' '+ hour + ':' + minute;
    }


    fileLimit = function(file){
       var uploadErrors = [];
       var acceptFileTypes = /^video\/(3gp|avi|m3u8|mpg|asf|wmv|mov|ts|webm|mp4|mkv|mpeg4|mpeg|mpe|x-flv)$/i;
       if(file['type'].length && !acceptFileTypes.test(file['type'])) {
            uploadErrors.push('Not an accepted file type');
        }
        if(file['size'] && file['size'] > 1073741824) {
            uploadErrors.push('Filesize is too big');
        }
        if(uploadErrors.length > 0) {
            alert(uploadErrors.join("\n")); 
            return true;
        }else{
            return false;
        }
    }
    function fileToken(){
     var jqXHR = $.ajax({
      url: token_url,
      type: 'GET',
      dataType: 'html',
      async: false
    });
     return jqXHR.responseText;
   }

   var token_url = $('#token_url').text();
   var authenticity_token = $("input[name=authenticity_token]").val();
   var utf8 = $("input[name=utf8]").val();
    var filelists = []
    var uploadedlists = []
    $('#fileupload').fileupload({
        dataType: 'json',
        // maxChunkSize: 10000SublimeLinter000, // 10MB chunksize
        autoUpload: false,
        sequentialUploads: true,
        progressInterval: 800,
        bitrateInterval: 500,
        // limitConcurrentUploads: 2,
        // filesContainer: $('table.files'),
        // uploadTemplateId: null,
        // downloadTemplateId: null,
        done: function (e, data) {
            for(var i = 0, l = data.files.length; i < l; i++) {
               file = data.files[i];
               var id = filelists.indexOf(file.name);
            // $.each(data.result.files, function (index, file) {
               // var id = filelists.indexOf(file.name);
               // $('#row_upload_' + id).find('td.status').text('completd')
               $('#row_upload_' + id).find('.upload_status').show().text('上传完成');
               $('#row_upload_' + id).find('.bar').hide();
               $('#row_upload_' + id).find('.bitrate').hide();

               $('#row_upload_' + id).find('.start').hide();
               $('#row_upload_' + id).find('.cancel').hide();
               $('#row_upload_' + id).find('.remove').show().click(function(e){
                    e.preventDefault();
                    $('#row_upload_' + id).remove();
                    delete  filelists[filelists.indexOf(file.name)];
                    delete  uploadedlists[uploadedlists.indexOf(file.name)];
               });
               // uploadedlists.push(file.name);
               if(! (uploadedlists.indexOf(file.name) != -1)) {
                 uploadedlists.push(file.name);
             }
         }
            // });
        },
        fail: function (e, data) {
            // xie = data
            // if (data.textStatus == 'error') {
            //     alert(data.errorThrown)
            //     return false;
            // };
            for(var i = 0, l = data.files.length; i < l; i++) {
               file = data.files[i];
               var id = filelists.indexOf(file.name);
               $('#row_upload_' + id).find('.upload_status').show().text('failed ' + data.errorThrown);
               $('#row_upload_' + id).find('.bar').hide();
               $('#row_upload_' + id).find('.bitrate').hide();
             }
        },
        // progressall: function (e, data) {
        // 	var progress = parseInt(data.loaded / data.total * 100, 10);
        // 	$('#progress .bar').css(
        // 		'width',
        // 		progress + '%'
        // 		);
        // },
        submit: function (e, data) {
            // xie = data;
            for(var i = 0, l = data.files.length; i < l; i++) {
               file = data.files[i];
               var id = filelists.indexOf(file.name);
               var file_categary = $('#row_upload_' + id).find('.file_strategy select').val();
               var file_strategy = $('#row_upload_' + id).find('.file_strategy select').val();
               // var form_value = $('#row_upload_' + id).find('.title input').val();
               // 是否文件己经上传
               if(uploadedlists.indexOf(file.name) != -1) {
                    return false;
                 }
              var token = fileToken();
              if (!token) {
                    return false;
                  };

              data.formData = {categary: file_categary, strategy_id: file_strategy, token: token, utf8: utf8, authenticity_token: authenticity_token};
               if (!data.formData.categary) {
                  alert('请为: ' + file.name + '选择视频分类');
                  // data.context.find('button').prop('disabled', false);
                  // input.focus();
                  return false;
              }        
               if (!data.formData.strategy_id) {
                  alert('请为: ' + file.name + '转码方案');
                  return false;
              }        
            }
      },
      progress: function (e, data) {
            var progress = Math.floor(data.loaded / data.total * 100);
            if (data.context) {
                data.context.each(function (index) {
                    file = data.files[index]
                 var id = filelists.indexOf(file.name);
                    $('#row_upload_' + id).find('.process_bar')
                    .css(
                        'width',
                        progress + '%'
                        );
                    $('#row_upload_' + id).find('.bitrate').text(formatBitrate(data.bitrate));
                });
            }
        },
      send: function (e, data) {
        for(var i = 0, l = data.files.length; i < l; i++) {
           file = data.files[i];
           var id = filelists.indexOf(file.name);
           $('#row_upload_' + id).find('.upload_status').hide();
           $('#row_upload_' + id).find('.bar').show();
           $('#row_upload_' + id).find('.bitrate').show();
           }
        },

        add: function (e, data) {
            var html = tmpl("template-upload", data);
            for(var i = 0, l = data.files.length; i < l; i++) {
               file = data.files[i];
                // 不能重复载入文件
                if(filelists.indexOf(file.name) != -1) {
                    alert('您己经增加了:' + file.name);
                   continue;
               }
               if (fileLimit(file)) {
                  continue;
               };

               $("#up_btn").on('click', function (e) {
                     e.preventDefault();
                     data.submit();
                });

               filelists.push(file.name);
                var id = 'row_upload_' + filelists.indexOf(file.name);
                data.context = $(html).attr('id', id).appendTo($('#upload_files'));
                data.context.find('.start').click(function (e) {
                    data.submit();
                    e.preventDefault();
                });
                $('#' + id).find('.cancel').click(function(){
                    $('#' + id).remove();
                    delete  filelists[filelists.indexOf(file.name)]
                    delete  uploadedlists[uploadedlists.indexOf(file.name)]
                });
            // })
            }
        },
        });
    });
