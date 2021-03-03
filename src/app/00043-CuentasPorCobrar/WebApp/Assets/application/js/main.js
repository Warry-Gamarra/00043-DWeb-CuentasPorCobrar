
$(document).on('ready', function () {
    $('#btnsubmit').removeClass('disabled');
    $('#btnCancel').removeClass('disabled');
});

function Load() {
    $('#loading').show();
    $('#btnsubmit').addClass('disabled');
    $('#btnCancel').addClass('disabled');
    $('#modal-container').attr('data-backdrop', 'static');
}

function Stop() {
    $('#loading').hide();
    $('#btnCancel').removeClass('disabled');
    $('#modal-container').removeAttr('data-backdrop');
}

function Submited() {
    var submited = parseInt($("#submited").val());
    $("#submited").val(submited + 1);
}

function Begin() {
    $('#loading').show();
    $('#div-resultado').html('');
    $('#div-resultado').hide();
}

function onComplete() {
    $('#loading').hide();
    $('#div-resultado').show();
}

function ChangeStateReloadPage(RowID, B_habilitado, ActionName) {
    var parametros = {
        RowID: RowID,
        B_habilitado: B_habilitado
    };
    $.ajax({
        cache: false,
        url: ActionName,
        type: "POST",
        data: parametros,
        dataType: "json",
        beforeSend: function () {
            $('#loader' + RowID).css("display", "inline");
        },
        success: function (data) {
            $('#loader' + RowID).css("display", "none");
            if (data['Value']) {
                $('#td' + RowID).html(data['Message']);

                location.reload();
            }
            else {
                toastr.warning(data['Message']);
            }
        },
        error: function () {
            $('#loader' + RowID).css("display", "none");

            toastr.error("No se pudo actualizar el estado. Intente nuevamente en unos segundos.<br /> Si el problema persiste comuníquese con el área de soporte de la aplicación.");
        }
    });

}
