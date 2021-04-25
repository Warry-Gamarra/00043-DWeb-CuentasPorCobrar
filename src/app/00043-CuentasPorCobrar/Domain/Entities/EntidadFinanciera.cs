using Data.Tables;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class EntidadFinanciera : IEntidadFinanciera
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public bool Habilitado { get; set; }
        public bool ArchivosEntidad { get; set; }
        public DateTime? FechaActualiza { get; set; }
        public Response Response { get; set; }



        private readonly TC_EntidadFinanciera _entFinanRepository;
        private readonly TI_TipoArchivo_EntidadFinanciera _archivoEntFinanRepository;

        public EntidadFinanciera()
        {
            _entFinanRepository = new TC_EntidadFinanciera();
            _archivoEntFinanRepository = new TI_TipoArchivo_EntidadFinanciera();
            this.Response = new Response() { Value = true };
        }

        public EntidadFinanciera(TC_EntidadFinanciera table, bool tieneArchivos)
        {
            this.Id = table.I_EntidadFinanID;
            this.Nombre = table.T_EntidadDesc;
            this.Habilitado = table.B_Habilitado;
            this.ArchivosEntidad = tieneArchivos;
            this.FechaActualiza = table.D_FecMod.HasValue ? table.D_FecMod.Value : table.D_FecCre;
            this.Response = new Response() { Value = true };
        }



        public Response ChangeState(int entidadFinanId, bool currentState, int currentUserId)
        {
            _entFinanRepository.I_EntidadFinanID = entidadFinanId;
            _entFinanRepository.D_FecMod = DateTime.Now;
            _entFinanRepository.B_Habilitado = !currentState;

            return new Response(_entFinanRepository.ChangeState(currentUserId));
        }

        public List<EntidadFinanciera> Find()
        {
            var result = new List<EntidadFinanciera>();
            var archivosEntidad = _archivoEntFinanRepository.Find();
            foreach (var item in _entFinanRepository.Find())
            {
                bool tieneArchivos = ExisteListaArchivos(item.I_EntidadFinanID, archivosEntidad);
                result.Add(new EntidadFinanciera(item, tieneArchivos));
            }

            return result;
        }

        public EntidadFinanciera Find(int entidadFinanId)
        {
            var data = _entFinanRepository.Find(entidadFinanId);
            var archivosEntidad = _archivoEntFinanRepository.FindByEntityID(entidadFinanId);

            if (data != null)
            {
                bool tieneArchivos = ExisteListaArchivos(entidadFinanId, archivosEntidad); ;
                return new EntidadFinanciera(data, tieneArchivos);
            }
            return new EntidadFinanciera()
            {
                Response = new Response()
                {
                    Value = false,
                    Message = "No se encontraron resultados para el identificador de la entidad financiera."
                }
            };
        }

        public Response Save(EntidadFinanciera entidadFinanciera, int currentUserId, SaveOption saveOption)
        {
            _entFinanRepository.I_EntidadFinanID = entidadFinanciera.Id;
            _entFinanRepository.T_EntidadDesc = entidadFinanciera.Nombre;
            _entFinanRepository.B_Habilitado = entidadFinanciera.Habilitado;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _entFinanRepository.D_FecCre = DateTime.Now;
                    return new Response(_entFinanRepository.Insert(entidadFinanciera.ArchivosEntidad, currentUserId));

                case SaveOption.Update:
                    _entFinanRepository.D_FecMod = DateTime.Now;
                    return new Response(_entFinanRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }

        public Response HabilitarArchivos(int entidadFinanId, int currentUserId)
        {
            _archivoEntFinanRepository.I_EntidadFinanID = entidadFinanId;
            _archivoEntFinanRepository.I_UsuarioCre = currentUserId;
            _archivoEntFinanRepository.D_FecCre = DateTime.Now;

            return new Response(_archivoEntFinanRepository.HabilitarArchivosEntidadFinanciera());
        }


        private bool ExisteListaArchivos(int entidadFinancieraId, List<TI_TipoArchivo_EntidadFinanciera> archivosEntidad)
        {
            if (archivosEntidad.Where(x => x.I_EntidadFinanID == entidadFinancieraId).Count() > 0)
            {
                return true;
            }
            return false;
        }
    }
}
