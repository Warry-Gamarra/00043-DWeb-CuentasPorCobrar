using Data.Procedures;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class HelperResources : IHelpResources
    {
        private readonly USP_S_DocumentacionUsuarioRoles _docUsuarioRepository;

        public int Id { get; set; }
        public string Documento { get; set; }
        public string Url { get; set; }
        public bool Habilitado { get; set; }
        public int Rol { get; private set; }
        public bool RolHabilitado { get; set; }
        public Response Response { get; set; }


        public HelperResources()
        {
            _docUsuarioRepository = new USP_S_DocumentacionUsuarioRoles();
        }

        public HelperResources(USP_S_DocumentacionUsuarioRoles table)
        {
            this.Id = table.I_RutaDocID;
            this.Documento = table.T_DocDesc;
            this.Url = table.T_RutaDocumento;
            this.Habilitado = table.B_Habilitado;
            this.Rol = table.RoleId;
            this.RolHabilitado = table.B_DocRolHabilitado;
        }



        public Response ChangeState(int rutaDocId, bool currentState, int currentUserId)
        {
            _docUsuarioRepository.I_RutaDocID = rutaDocId;
            //_docUsuarioRepository.D_FecMod = DateTime.Now;
            _docUsuarioRepository.B_Habilitado = !currentState;

            return new Response(_docUsuarioRepository.ChangeState(currentUserId));
        }

        public List<HelperResources> Find()
        {
            var result = new List<HelperResources>();
            foreach (var item in _docUsuarioRepository.Execute())
            {
                result.Add(new HelperResources(item));
            }

            return result;
        }

        public List<HelperResources> Find(int rutaDocumentoId)
        {
            var result = new List<HelperResources>();
            var data = _docUsuarioRepository.Execute().Where(x => x.I_RutaDocID == rutaDocumentoId);
            if (data != null)
            {
                foreach (var item in data)
                {
                    result.Add(new HelperResources(item));
                }

                return result;
            }
            return new List<HelperResources>();

        }

        public Response Save(HelperResources manualUsuario, DataTable dtRoles, int currentUserId, SaveOption saveOption)
        {
            _docUsuarioRepository.I_RutaDocID = manualUsuario.Id;
            _docUsuarioRepository.T_DocDesc = manualUsuario.Documento;
            _docUsuarioRepository.T_RutaDocumento = manualUsuario.Url;
            _docUsuarioRepository.B_Habilitado = manualUsuario.Habilitado;


            switch (saveOption)
            {
                case SaveOption.Insert:
                    //_docUsuarioRepository.D_FecCre = DateTime.Now;
                    return new Response(_docUsuarioRepository.Insert(dtRoles, currentUserId));

                case SaveOption.Update:
                    //_docUsuarioRepository.D_FecMod = DateTime.Now;
                    return new Response(_docUsuarioRepository.Update(dtRoles, currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inválida."
            };
        }
    }
}
